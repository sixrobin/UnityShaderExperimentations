using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class BlackContour : MonoBehaviour
{
    [Range(0.0f, 2.0f)]
    public float _contour = 1.0f;
    [Range(0.0f, 2.0f)]
    public float _vignette = 1.0f;

    Camera cam;

    private Shader blackContourShader = null;
    private Material blackContourMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        blackContourShader = Shader.Find("MyShaders/BlackContour");
        blackContourMaterial = CheckShader(blackContourShader, blackContourMaterial);

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
        DestroyImmediate(blackContourMaterial);
#else
        Destroy(blackContourMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        blackContourMaterial.SetFloat("_contour", _contour);
        blackContourMaterial.SetFloat("_vignette", _vignette);

        Graphics.Blit (source, destination, blackContourMaterial);
	}
}
