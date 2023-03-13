using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Arcade : MonoBehaviour
{
    [Range(0.0f, 2.0f)]
    public float _contour = 1.0f;
    [Range(0.0f, 2.0f)]
    public float _vignette = 0.75f;
    [Range(0.0f, 1.0f)]
    public float _aberration = 0.5f;
    [Range(0.0f, 1.0f)]
    public float _lens = 0.25f;
    [Range(0.0f, 1.0f)]
    public float _cubic = 0.1f;
    [Range(0.0f, 1.0f)]
    public float _intensity = 0.25f;
    [Range(-2.0f, 2.0f)]
    public float _speed = 0.4f;

    Camera cam;

    private Shader arcadeShader = null;
    private Material arcadeMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        arcadeShader = Shader.Find("Hidden/Arcade");
        arcadeMaterial = CheckShader(arcadeShader, arcadeMaterial);

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
        DestroyImmediate(arcadeMaterial);
#else
        Destroy(arcadeMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
	    if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        arcadeMaterial.SetFloat("_contour", _contour);
        arcadeMaterial.SetFloat("_vignette", _vignette);
        arcadeMaterial.SetFloat("_aberration", _aberration);
        arcadeMaterial.SetFloat("_lens", 1 - _lens);
        arcadeMaterial.SetFloat("_intensity", _intensity);
        arcadeMaterial.SetFloat("_cubic", _cubic);
        arcadeMaterial.SetFloat("_speed", _speed);

        Graphics.Blit (source, destination, arcadeMaterial);
	}
}
