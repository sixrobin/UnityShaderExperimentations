using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class MechanicalDistortion : MonoBehaviour
{
    [Range(-1.0f, 1.0f)]
    public float _speedX = 0.5f;
    [Range(-1.0f, 1.0f)]
    public float _speedY = -0.5f;
    [Range(0.0f, 5.0f)]
    public float _strength = 2.0f;

    public enum filterMode { Point, Bilinear, Trilinear };
    public filterMode _filterMode;

    string[] normalMap = new string[]
    {
        "0101010101010101",
        "1010101010101010",
        "0101010101010101",
        "1010101010101010",
        "0101010101010101",
        "1010101010101010",
        "0101010101010101",
        "1010101010101010",
        "0101010101010101",
        "1010101010101010",
        "0101010101010101",
        "1010101010101010",
        "0101010101010101",
        "1010101010101010",
        "0101010101010101",
        "1010101010101010"
    };

    Texture2D _normalMap;
    int width = 16;
    int height = 16;

    Camera cam;

    private Shader mechanicalDistortionShader = null;
	private Material mechanicalDistortionMaterial = null;
    bool isSupported = true;

    void Awake()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        mechanicalDistortionShader = Shader.Find("MyShaders/MechanicalDistortion");
        mechanicalDistortionMaterial = CheckShader(mechanicalDistortionShader, mechanicalDistortionMaterial);

        return isSupported;
    }

    protected Material CheckShader(Shader s, Material m)
    {
        if (s == null)
        {
            Debug.Log("Missing shader on " + ToString());
            this.enabled = false;
            return null;
        }

        if (s.isSupported == false)
        {
            Debug.Log("The shader " + s.ToString() + " is not supported on this platform");
            this.enabled = false;
            return null;
        }

        cam = GetComponent<Camera>();
        cam.renderingPath = RenderingPath.UsePlayerSettings;

        m = new Material(s);
        m.hideFlags = HideFlags.DontSave;

        if (s.isSupported && m && m.shader == s)
            return m;

        return m;
    }

    void Start()
    {
        _normalMap = new Texture2D(width, height, TextureFormat.ARGB32, false);

        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                if (normalMap[j].Substring(i, 1) == "1")
                    _normalMap.SetPixel(i, j, Color.black);
                else
                    _normalMap.SetPixel(i, j, Color.white);
            }
        }

        _normalMap.Apply();
    }

    void OnDestroy()
    {
#if UNITY_EDITOR
        DestroyImmediate(mechanicalDistortionMaterial);
#else
        Destroy(mechanicalDistortionMaterial);
#endif
    }

	void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        _normalMap.wrapMode = TextureWrapMode.Repeat;

        if (_filterMode == filterMode.Point)
            _normalMap.filterMode = FilterMode.Point;
        if (_filterMode == filterMode.Bilinear)
            _normalMap.filterMode = FilterMode.Bilinear;
        if (_filterMode == filterMode.Trilinear)
            _normalMap.filterMode = FilterMode.Trilinear;

        mechanicalDistortionMaterial.SetFloat ("_speedX", _speedX * 2);
        mechanicalDistortionMaterial.SetFloat ("_speedY", _speedY * 2);
        mechanicalDistortionMaterial.SetTexture ("_normalMap", _normalMap);
        mechanicalDistortionMaterial.SetFloat("_strength", _strength);

        Graphics.Blit(source, destination, mechanicalDistortionMaterial);
	}
}
