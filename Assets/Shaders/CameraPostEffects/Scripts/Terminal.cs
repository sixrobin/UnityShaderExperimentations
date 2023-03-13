using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Terminal : MonoBehaviour
{
    [Range(0.0f, 2.0f)]
    public float _contour = 1.0f;
    [Range(0.0f, 2.0f)]
    public float _vignette = 0.7f;
    [Range(0.0f, 1.0f)]
    public float _intensity = 0.5f;
    [Range(-2.0f, 2.0f)]
    public float _speed = 0.5f;
    [Range(0.0f, 1.0f)]
    public float _global = 0.5f;

    Camera cam;

    private Shader terminalShader = null;
    private Material terminalMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        terminalShader = Shader.Find("MyShaders/Terminal");
        terminalMaterial = CheckShader(terminalShader, terminalMaterial);

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
        DestroyImmediate(terminalMaterial);
#else
        Destroy(terminalMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        terminalMaterial.SetFloat("_contour", _contour);
        terminalMaterial.SetFloat("_vignette", _vignette);
        terminalMaterial.SetFloat("_speed", _speed);
        terminalMaterial.SetFloat("_intensity", _intensity);
        terminalMaterial.SetFloat("_global", 2 - _global);

        Graphics.Blit (source, destination, terminalMaterial);
	}
}
