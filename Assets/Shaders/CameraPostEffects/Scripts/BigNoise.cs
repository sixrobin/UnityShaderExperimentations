using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class BigNoise : MonoBehaviour
{
    [Range(-5.0f, 5.0f)]
    public float _frequency = 2.0f;
    [Range(-5.0f, 5.0f)]
    public float _contrast = 2.0f;
    [Range(1.0f, 5.0f)]
    public float _size = 2.0f;
    [Range(0.0f, 1.0f)]
    public float _dispersal = 0.25f;

    Camera cam;

    private Shader bigNoiseShader = null;
    private Material bigNoiseMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        bigNoiseShader = Shader.Find("MyShaders/BigNoise");
        bigNoiseMaterial = CheckShader(bigNoiseShader, bigNoiseMaterial);

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
        DestroyImmediate(bigNoiseMaterial);
#else
        Destroy(bigNoiseMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
        if (CheckResources() == false)
	    {
			Graphics.Blit (source, destination);
			return;
		}

        float _f = _frequency;
        float _c = _contrast;

        _f += Mathf.Sin(Time.time * 10) * _dispersal;
        _c -= Mathf.Sin(Time.time * 50) * _dispersal;

        bigNoiseMaterial.SetFloat("_frequency", _f);
        bigNoiseMaterial.SetFloat("_contrast", _c);
        bigNoiseMaterial.SetFloat("_size", _size);
        bigNoiseMaterial.SetFloat("_dispersal", _dispersal);

        Graphics.Blit (source, destination, bigNoiseMaterial);
	}
}
