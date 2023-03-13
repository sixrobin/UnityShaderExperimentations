using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class ColorFilter : MonoBehaviour
{
    public Color _color = Color.cyan;

    Camera cam;

    private Shader colorFilterShader = null;
	private Material colorFilterMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        colorFilterShader = Shader.Find("MyShaders/ColorFilter");
        colorFilterMaterial = CheckShader(colorFilterShader, colorFilterMaterial);

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
        DestroyImmediate(colorFilterMaterial);
#else
        Destroy(colorFilterMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        colorFilterMaterial.SetColor("_color", _color);

        Graphics.Blit (source, destination, colorFilterMaterial);
	}
}
