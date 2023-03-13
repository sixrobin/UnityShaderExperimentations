using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Laplacian : MonoBehaviour
{
    [Range(0.01f, 1.0f)]
    public float _amplitude = 0.25f;

    public bool DBZ = false;
    public bool _invert = false;

    Camera cam;

    private Shader laplacianShader = null;
    private Material laplacianMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        laplacianShader = Shader.Find("MyShaders/Laplacian");
        laplacianMaterial = CheckShader(laplacianShader, laplacianMaterial);

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
        DestroyImmediate(laplacianMaterial);
#else
        Destroy(laplacianMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}
        // division by zero
        if (DBZ == true)
            laplacianMaterial.EnableKeyword("DBZ");
        else
            laplacianMaterial.DisableKeyword("DBZ");

        if (_invert == true)
            laplacianMaterial.EnableKeyword("INVERT");
        else
            laplacianMaterial.DisableKeyword("INVERT");

        laplacianMaterial.SetFloat("_amplitude", _amplitude);

        Graphics.Blit (source, destination, laplacianMaterial);
	}
}
