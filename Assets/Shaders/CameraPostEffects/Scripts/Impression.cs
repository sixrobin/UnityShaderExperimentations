using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Impression : MonoBehaviour
{
    public Texture2D _dot;

    string[] dot = new string[]
    {
        "00000000",
        "00000000",
        "00111100",
        "00111100",
        "00111100",
        "00111100",
        "00000000",
        "00000000"
    };

    int width = 8;
    int height = 8;

    public int _tilesX = 160;
    public int _tilesY = 90;
    [Range(0.0f, 1.0f)]
    public float _threshold = 0.5f;

    Camera cam;

    private Shader impressionShader = null;
    private Material impressionMaterial = null;
    bool isSupported = true;

    void Awake()
    {
        if (_dot == null)
            _dot = new Texture2D(width, height, TextureFormat.ARGB32, false);

        _dot.wrapMode = TextureWrapMode.Clamp;

        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                if (dot[j].Substring(i, 1) == "1")
                   _dot.SetPixel(i, j, Color.white);
                else
                   _dot.SetPixel(i, j, Color.clear);
            }
        }

        _dot.Apply();
    }

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        impressionShader = Shader.Find("MyShaders/Impression");
        impressionMaterial = CheckShader(impressionShader, impressionMaterial);

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

    void OnDestroy()
    {
#if UNITY_EDITOR
        DestroyImmediate(impressionMaterial);
#else
        Destroy(impressionMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        impressionMaterial.SetTexture("_mapTexture", _dot);
        impressionMaterial.SetFloat("_tilesX", _tilesX);
        impressionMaterial.SetFloat("_tilesY", _tilesY);
        impressionMaterial.SetFloat("_contrast", _threshold);

        Graphics.Blit (source, destination, impressionMaterial);
	}
}
