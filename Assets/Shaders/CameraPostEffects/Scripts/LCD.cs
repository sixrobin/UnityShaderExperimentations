using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class LCD : MonoBehaviour
{
    [Range(0.0f, 2.0f)]
    public float _contour = 1.0f;
    [Range(0.0f, 2.0f)]
    public float _vignette = 1.0f;
    [Range(0.0f, 1.0f)]
    public float _intensity = 0.5f;

    public Color _color = Color.gray;

    Camera cam;

    private int _resX;
    private int _resY;

    private Shader lcdShader = null;
    private Material lcdMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();

        _resX = Screen.width;
        _resY = Screen.height;
    }

    public bool CheckResources()
    {
        lcdShader = Shader.Find("MyShaders/LCD");
        lcdMaterial = CheckShader(lcdShader, lcdMaterial);

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
        DestroyImmediate(lcdMaterial);
#else
        Destroy(lcdMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        cam.backgroundColor = _color;

        lcdMaterial.SetFloat("_contour", _contour);
        lcdMaterial.SetFloat("_vignette", _vignette);
        lcdMaterial.SetFloat("_intensity", _intensity);
        lcdMaterial.SetInt("_resX", _resX);
        lcdMaterial.SetInt("_resY", _resY);

        Graphics.Blit (source, destination, lcdMaterial);
	}
}
