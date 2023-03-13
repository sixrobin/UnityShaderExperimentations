using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Psycho : MonoBehaviour
{
    [Range(0.0f, 10.0f)]
    public float _strength = 5.0f;
    [Range(0.0f, 5.0f)]
    public float _speed = 1.0f;
    [Range(0.01f, 1.0f)]
    public float _parasite = 0.5f;

    Camera cam;

    private Shader psychoShader = null;
    private Material psychoMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        psychoShader = Shader.Find("MyShaders/Psycho");
        psychoMaterial = CheckShader(psychoShader, psychoMaterial);

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
        DestroyImmediate(psychoMaterial);
#else
        Destroy(psychoMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}
        
        psychoMaterial.SetFloat("_strength", _strength);
        psychoMaterial.SetFloat("_speed", _speed);
        psychoMaterial.SetFloat("_parasite", _parasite);

        Graphics.Blit (source, destination, psychoMaterial);
	}
}
