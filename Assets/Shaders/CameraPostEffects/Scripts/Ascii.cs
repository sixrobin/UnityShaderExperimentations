using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Ascii : MonoBehaviour
{
    [Range(1, 5)]
    public int _scale = 2;
    public bool _pixelated = false;

    Camera cam;

    private Shader asciiShader = null;
    private Material asciiMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        asciiShader = Shader.Find("MyShaders/Ascii");
        asciiMaterial = CheckShader(asciiShader, asciiMaterial);

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
        cam.renderingPath = RenderingPath.DeferredLighting;

        m = new Material(s);
        m.hideFlags = HideFlags.DontSave;

        if (s.isSupported && m && m.shader == s)
            return m;

        return m;
    }

    void OnDestroy()
    {
#if UNITY_EDITOR
        DestroyImmediate(asciiMaterial);
#else
        Destroy(asciiMaterial);
#endif
    }

	void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        asciiMaterial.SetInt("_scale", _scale);

        if (_pixelated == true)
            asciiMaterial.EnableKeyword("PIXELATED");
        else
            asciiMaterial.DisableKeyword("PIXELATED");

        Graphics.Blit (source, destination, asciiMaterial);
	}
}
