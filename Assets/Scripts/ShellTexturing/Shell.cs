using UnityEngine;

public class Shell : MonoBehaviour
{
    private static readonly int MASK_SHADER_ID = Shader.PropertyToID("_Mask");
    private static readonly int COLOR_SHADER_ID = Shader.PropertyToID("_Color");

    [SerializeField]
    private GameObject _quadPrefab;
    [SerializeField]
    private Material _shellLayerMaterial;

    [SerializeField]
    private Color _downColor = Color.black;
    [SerializeField]
    private Color _upColor = Color.white;

    [SerializeField]
    private int _resolution = 32;
    [SerializeField]
    private float _height;
    [SerializeField, Min(2)]
    private int _count;
    [SerializeField]
    private int _seed = -1;
    [SerializeField, Range(0f, 1f)]
    private float _maskInitRandomStep = 0.9f;
    [SerializeField, Range(0f, 1f)]
    private float _maskLastRandomStep = 0.1f;

    private bool _dirty;
    
    private void Refresh()
    {
        if (this._quadPrefab == null)
            return;

        for (int i = this.transform.childCount - 1; i >= 0; --i)
            Destroy(this.transform.GetChild(i).gameObject);
        
        this.GenerateQuads();
    }

    private Texture2D GenerateMask(int index)
    {
        RSLib.RandomNumberGenerator rng = new(this._seed);
        float step = (this._maskInitRandomStep - this._maskLastRandomStep) / (this._count - 1) * index;

        Color[] colors = new Color[this._resolution * this._resolution];
        for (int i = 0; i < colors.Length; ++i)
            colors[i] = rng.RandomValue(this) > step ? Color.white : Color.black;

        Texture2D texture2D = new(this._resolution, this._resolution, TextureFormat.RGB24, false)
        {
            wrapMode = TextureWrapMode.Repeat,
            filterMode = FilterMode.Point,
        };
        
        texture2D.SetPixels(colors);
        texture2D.Apply();
        
        return texture2D;
    }
    
    private void GenerateQuads()
    {
        float step = this._height / (this._count - 1);
        
        for (int i = 0; i < this._count; ++i)
        {
            GameObject quadInstance = Instantiate(this._quadPrefab, Vector3.zero, this._quadPrefab.transform.rotation, this.transform);
            quadInstance.transform.Translate(Vector3.up * (step * i), Space.World);

            Material quadMaterial = new(this._shellLayerMaterial);
            Texture2D mask = this.GenerateMask(i);
            quadMaterial.SetTexture(MASK_SHADER_ID, mask);
            quadMaterial.SetColor(COLOR_SHADER_ID, Color.Lerp(this._downColor, this._upColor, i / (float)(this._count - 1)));
            quadInstance.GetComponent<MeshRenderer>().material = quadMaterial;
        }
    }

    private void Start()
    {
        this._dirty = true;
    }

    private void Update()
    {
        if (this._dirty)
        {
            this.Refresh();
            this._dirty = false;
        }
    }

    private void OnValidate()
    {
        this._dirty = true;
    }
}
