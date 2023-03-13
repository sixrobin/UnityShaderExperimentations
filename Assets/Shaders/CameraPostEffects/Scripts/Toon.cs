using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Toon : MonoBehaviour
{
    [Range(0.1f, 1.0f)]
    public float _strength = 0.5f;
    [Range(2, 10)]
    public int _posterization = 4;
    [Range(0.01f, 1.0f)]
    public float _global = 0.2f;

    public bool _grayscale;

    Camera cam;

    private Shader toonShader = null;
    private Material toonMaterial = null;
    bool isSupported = true;

    void Start()
    {   
        CheckResources();
    }

    public bool CheckResources ()
    {
        toonShader = Shader.Find ("MyShaders/Toon");
        toonMaterial = CheckShader(toonShader, toonMaterial);

        return isSupported;
    }

    protected Material CheckShader(Shader s, Material m)
    {
        if (s == null)
        {
            Debug.Log("Missing shader in " + ToString());
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
        DestroyImmediate(toonMaterial);
#else
        Destroy(toonMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        toonMaterial.SetFloat("_strength", 1 - _strength);
        toonMaterial.SetInt("_poster", _posterization);
        toonMaterial.SetFloat("_global", 1 - _global);
            
        if (_grayscale == true)
            toonMaterial.EnableKeyword("GRAYSCALE");
        else
            toonMaterial.DisableKeyword("GRAYSCALE");

        Graphics.Blit (source, destination, toonMaterial);
    }
}
