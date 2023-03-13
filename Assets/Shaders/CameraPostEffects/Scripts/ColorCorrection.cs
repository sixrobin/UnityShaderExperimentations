using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class ColorCorrection : MonoBehaviour
{
    [Range(0.0f, 1.0f)]
    public float _intensityR = 0.5f;
    [Range(0.0f, 1.0f)]
    public float _intensityG = 0.5f;
    [Range(0.0f, 1.0f)]
    public float _intensityB = 0.5f;

    public Texture _rgbTex;

    Camera cam;

    private Shader colorCorrectionShader = null;
    private Material colorCorrectionMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        colorCorrectionShader = Shader.Find("MyShaders/ColorCorrection");
        colorCorrectionMaterial = CheckShader(colorCorrectionShader, colorCorrectionMaterial);

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
        DestroyImmediate(colorCorrectionMaterial);
#else
        Destroy(colorCorrectionMaterial);
#endif
    }

    void Awake()
    {
        if (_rgbTex == null)
            _rgbTex = Resources.Load("Ramp01") as Texture;
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
	    if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

		colorCorrectionMaterial.SetTexture ("_rgbTex", _rgbTex);
        colorCorrectionMaterial.SetFloat("_intensityR", _intensityR * 2);
        colorCorrectionMaterial.SetFloat("_intensityG", _intensityG * 2);
        colorCorrectionMaterial.SetFloat("_intensityB", _intensityB * 2);

        Graphics.Blit (source, destination, colorCorrectionMaterial);
	}
}
