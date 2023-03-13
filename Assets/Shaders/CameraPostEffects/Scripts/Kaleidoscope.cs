using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Kaleidoscope : MonoBehaviour
{
    [Range(1, 16)]
    public int _segment = 6;
    [Range(0.0f, 5.0f)]
    public float _strength = 2.5f;
    [Range(0.0f, 1.0f)]
    public float _speed = 0.5f;

    public bool _invert = false;
    public bool _sinWave = false;

    Camera cam;

    private Shader kaleidoscopeShader = null;
    private Material kaleidoscopeMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        kaleidoscopeShader = Shader.Find("MyShaders/Kaleidoscope");
        kaleidoscopeMaterial = CheckShader(kaleidoscopeShader, kaleidoscopeMaterial);

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
        DestroyImmediate(kaleidoscopeMaterial);
#else
        Destroy(kaleidoscopeMaterial);
#endif
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (CheckResources() == false)
        {
            Graphics.Blit(source, destination);
            return;
        }

        var div = Mathf.PI * 2 / Mathf.Max(1, _segment);

        if (_invert == true)
            kaleidoscopeMaterial.EnableKeyword("INVERT");
        else
            kaleidoscopeMaterial.DisableKeyword("INVERT");

        if (_sinWave == true)
            kaleidoscopeMaterial.EnableKeyword("SIN_WAVE");
        else
            kaleidoscopeMaterial.DisableKeyword("SIN_WAVE");

        kaleidoscopeMaterial.SetFloat("_segment", div);
        kaleidoscopeMaterial.SetFloat("_strength", _strength * Mathf.Deg2Rad);
        kaleidoscopeMaterial.SetFloat("_speed", _speed);

        Graphics.Blit(source, destination, kaleidoscopeMaterial);
    }
}
