using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Parasite : MonoBehaviour
{
    [Range(-5.0f, 5.0f)]
    public float _frequency = 2.0f;
    [Range(-5.0f, 5.0f)]
    public float _contrast = 2.0f;
    [Range(0.0f, 10.0f)]
    public float _dispersal = 3.0f;

    public Texture _backGround;

    Camera cam;

    private Shader parasiteShader = null;
    private Material parasiteMaterial = null;
    bool isSupported = true;

    void Awake()
    {
        if (_backGround == null)
            _backGround = Resources.Load("Ramp02") as Texture;
    }

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        parasiteShader = Shader.Find("MyShaders/Parasite");
        parasiteMaterial = CheckShader(parasiteShader, parasiteMaterial);

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
        DestroyImmediate(parasiteMaterial);
#else
        Destroy(parasiteMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
        _frequency += Mathf.Sin(Time.time * (20 + UnityEngine.Random.Range(-_dispersal, _dispersal))) / 7.7f;
        _contrast -= Mathf.Sin(Time.time * (100 + UnityEngine.Random.Range(-_dispersal, _dispersal))) / 7.7f;

        if (_frequency >= _dispersal)
            _frequency = _dispersal;
        if (_frequency <= -_dispersal)
            _frequency = -_dispersal;

        if (_contrast >= _dispersal)
            _contrast = _dispersal;
        if (_contrast <= -_dispersal)
            _contrast = -_dispersal;

        if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        parasiteMaterial.SetFloat("_frequency", _frequency);
        parasiteMaterial.SetFloat("_contrast", _contrast);
        parasiteMaterial.SetTexture("_backGround", _backGround);

        Graphics.Blit (source, destination, parasiteMaterial);
	}
}
