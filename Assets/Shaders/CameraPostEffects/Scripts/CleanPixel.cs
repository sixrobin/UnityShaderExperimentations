using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class CleanPixel : MonoBehaviour
{
    public Color _volume = Color.white;
    public Color _global = Color.blue;

    [Range(2, 20)]
    public int _scale = 10;
    [Range(0.0f, 1.0f)]
    public float _threshold = 0.5f;

    Camera cam;

    private Shader cleanPixelShader = null;
    private Material cleanPixelMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        cleanPixelShader = Shader.Find("MyShaders/CleanPixel");
        cleanPixelMaterial = CheckShader(cleanPixelShader, cleanPixelMaterial);

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
        DestroyImmediate(cleanPixelMaterial);
#else
        Destroy(cleanPixelMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        cleanPixelMaterial.SetColor("_volume", _volume);
        cleanPixelMaterial.SetColor("_global", _global);
        cleanPixelMaterial.SetInt("_scale", _scale);
        cleanPixelMaterial.SetFloat("_threshold", _threshold);

        Graphics.Blit (source, destination, cleanPixelMaterial);
	}
}
