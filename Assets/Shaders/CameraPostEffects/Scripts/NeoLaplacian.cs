using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class NeoLaplacian : MonoBehaviour
{
    [Range(0.01f, 1.0f)]
    public float _amplitude = 0.1f;
    [Range(0.0f, 1.99f)]
    public float _size = 1.0f;
  
    public Color _color = Color.red;
    public bool _invert = false;

    Camera cam;

    private Shader neoLaplacianShader = null;
    private Material neoLaplacianMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        neoLaplacianShader = Shader.Find("MyShaders/NeoLaplacian");
        neoLaplacianMaterial = CheckShader(neoLaplacianShader, neoLaplacianMaterial);

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
        DestroyImmediate(neoLaplacianMaterial);
#else
        Destroy(neoLaplacianMaterial);
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

        int _resX = Screen.width;
        int _resY = Screen.height;

        if (_invert == true)
            neoLaplacianMaterial.EnableKeyword("INVERT");
        else
            neoLaplacianMaterial.DisableKeyword("INVERT");

        neoLaplacianMaterial.SetFloat("_amplitude", _amplitude);
        neoLaplacianMaterial.SetFloat("_size", 2 -_size);
        neoLaplacianMaterial.SetInt("_resX", _resX);
        neoLaplacianMaterial.SetInt("_resY", _resY);
           
        Graphics.Blit (source, destination, neoLaplacianMaterial);
	}
}
