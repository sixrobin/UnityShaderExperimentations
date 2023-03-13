using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Carnival : MonoBehaviour
{
    [Range(-10, 10)]
    public int _channel = 5;
    [Range(0.0f, 1.0f)]
    public float _intensityR = 0.5f;
    [Range(0.0f, 1.0f)]
    public float _intensityG = 0.5f;
    [Range(0.0f, 1.0f)]
    public float _intensityB = 0.5f;

    public Texture _rgbTex;

    Camera cam;

    private Shader carnivalShader = null;
	private Material carnivalMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();

        if (_rgbTex == null)
            _rgbTex = Resources.Load("Ramp02") as Texture;
    }

    public bool CheckResources()
    {
        carnivalShader = Shader.Find("MyShaders/Carnival");
        carnivalMaterial = CheckShader(carnivalShader, carnivalMaterial);

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
        DestroyImmediate(carnivalMaterial);
#else
        Destroy(carnivalMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

		carnivalMaterial.SetTexture ("_rgbTex", _rgbTex);
        carnivalMaterial.SetInt("_channel", _channel);
        carnivalMaterial.SetFloat("_intensityR", _intensityR * 2);
        carnivalMaterial.SetFloat("_intensityG", _intensityG * 2);
        carnivalMaterial.SetFloat("_intensityB", _intensityB * 2);

        Graphics.Blit (source, destination, carnivalMaterial);
	}
}
