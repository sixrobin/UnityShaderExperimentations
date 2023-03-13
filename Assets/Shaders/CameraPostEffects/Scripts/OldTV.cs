using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class OldTV : MonoBehaviour
{
    [Range(0.0f, 2.0f)]
    public float _contour = 1.0f;
    [Range(0.0f, 2.0f)]
    public float _vignette = 1.0f;
    [Range(0.0f, 1.0f)]
    public float _intensity = 0.5f;

    Camera cam;

    private Shader oldTvShader = null;
    private Material oldTvMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        oldTvShader = Shader.Find("MyShaders/OldTV");
        oldTvMaterial = CheckShader(oldTvShader, oldTvMaterial);

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
        DestroyImmediate(oldTvMaterial);
#else
        Destroy(oldTvMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        oldTvMaterial.SetFloat("_contour", _contour);
        oldTvMaterial.SetFloat("_vignette", _vignette);
        oldTvMaterial.SetFloat("_intensity", _intensity);

        Graphics.Blit (source, destination, oldTvMaterial);
	}
}
