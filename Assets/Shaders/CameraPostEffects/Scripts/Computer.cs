using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Computer : MonoBehaviour
{ 
    [Range(0.0f, 2.0f)]
    public float _contour = 1.0f;
    [Range(0.0f, 2.0f)]
    public float _vignette = 1.0f;
    [Range(-2.0f, 2.0f)]
    public float _speed = 0.5f;
    [Range(0.0f, 1.0f)]
    public float _noise = 0.5f;

    public Color _colorBG = Color.white;

    Camera cam;

    private Shader computerShader = null;
    private Material computerMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        computerShader = Shader.Find("MyShader/Computer");
        computerMaterial = CheckShader(computerShader, computerMaterial);

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
        DestroyImmediate(computerMaterial);
#else
        Destroy(computerMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        computerMaterial.SetFloat("_contour", _contour);
        computerMaterial.SetFloat("_vignette", _vignette);
        computerMaterial.SetColor("_colorBG", _colorBG);
        computerMaterial.SetFloat("_speed", _speed);
	    computerMaterial.SetFloat ("_noise", _noise);

		Graphics.Blit (source, destination, computerMaterial);
	}
}
