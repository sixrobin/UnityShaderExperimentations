using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Hypnotia : MonoBehaviour
{
    [Range(1, 16)]
    public int _segment = 6;
    [Range(0.0f, 5.0f)]
    public float _strength = 2.5f;
    [Range(0.0f, 1.0f)]
    public float _speed = 0.5f;

    public bool _invert = false;

    public Color _color = Color.red;

    Camera cam;

    private Shader hypnotiaShader = null;
    private Material hypnotiaMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        hypnotiaShader = Shader.Find("MyShaders/Hypnotia");
        hypnotiaMaterial = CheckShader(hypnotiaShader, hypnotiaMaterial);

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
        DestroyImmediate(hypnotiaMaterial);
#else
        Destroy(hypnotiaMaterial);
#endif
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (CheckResources() == false)
        {
            Graphics.Blit(source, destination);
            return;
        }

        cam.backgroundColor = _color;

        var div = Mathf.PI * 2 / Mathf.Max(1, _segment);

        if (_invert == true)
            hypnotiaMaterial.EnableKeyword("INVERT");
        else
            hypnotiaMaterial.DisableKeyword("INVERT");

        hypnotiaMaterial.SetFloat("_segment", div);
        hypnotiaMaterial.SetFloat("_strength", _strength * Mathf.Deg2Rad);
        hypnotiaMaterial.SetFloat("_speed", _speed * 400);

        Graphics.Blit(source, destination, hypnotiaMaterial);
    }
}
