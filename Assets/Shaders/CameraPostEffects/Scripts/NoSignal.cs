using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]

public class NoSignal : MonoBehaviour
{
    [Range(-5.0f, 5.0f)]
    public float _frequency = 2.0f;
    [Range(-5.0f, 5.0f)]
    public float _contrast = -2.0f;
    [Range(0.0f, 5.0f)]
    public float _dispersal = 2.0f;
    [Range(0.0f, 1.0f)]
    public float _ghost = 0.25f;

    public Texture _NoSignalTex;

    [Range(0.0f, 2.0f)]
    public float _contour = 1.0f;
    [Range(0.0f, 2.0f)]
    public float _vignette = 1.0f;

    public bool _monochroma = false;

    int _resX;
    int _resY;

    Camera cam;

    private Shader noSignalShader = null;
    private Material noSignalMaterial = null;
    bool isSupported = true;

    void Awake()
    {
        if (_NoSignalTex == null)
            _NoSignalTex = Resources.Load("NoSignal") as Texture;
    }

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        noSignalShader = Shader.Find("MyShaders/NoSignal");
        noSignalMaterial = CheckShader(noSignalShader, noSignalMaterial);

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
        DestroyImmediate(noSignalMaterial);
#else
        Destroy(noSignalMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
        if (CheckResources() == false)
        {
            Graphics.Blit(source, destination);
            return;
        }

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

        if (_monochroma == true)
            noSignalMaterial.EnableKeyword("MONOCHROMA");
        else
            noSignalMaterial.DisableKeyword("MONOCHROMA");

        noSignalMaterial.SetFloat("_frequency", _frequency);
        noSignalMaterial.SetFloat("_contrast", _contrast);
        noSignalMaterial.SetFloat("_ghost", _ghost/2);
        noSignalMaterial.SetTexture("_noSignal", _NoSignalTex);
        noSignalMaterial.SetFloat("_contour", _contour);
        noSignalMaterial.SetFloat("_vignette", _vignette);

        Graphics.Blit (source, destination, noSignalMaterial);
    }
}
