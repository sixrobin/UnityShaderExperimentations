using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Dysphoria : MonoBehaviour
{
    [Range(0.0f, 100.0f)]
    public float _strength = 30.0f;
    [Range(0.0f, 1.0f)]
    public float _amplitude = 0.55f;
    [Range(0.0f, 2.0f)]
    public float _speed = 1.0f;
       
    public bool _invert = false;

    Camera cam;

    private Shader dysphoriaShader = null;
    private Material dysphoriaMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        dysphoriaShader = Shader.Find("MyShaders/Dysphoria");
        dysphoriaMaterial = CheckShader(dysphoriaShader, dysphoriaMaterial);

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
        DestroyImmediate(dysphoriaMaterial);
#else
        Destroy(dysphoriaMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
		{
			if (CheckResources() == false)
			{
				Graphics.Blit (source, destination);
				return;
			}

        if (_invert == true)
            dysphoriaMaterial.EnableKeyword("INVERT");
        else
            dysphoriaMaterial.DisableKeyword("INVERT");

        dysphoriaMaterial.SetFloat ("_strength", _strength);
        dysphoriaMaterial.SetFloat("_amplitude", _amplitude);
        dysphoriaMaterial.SetFloat("_speed", _speed);

        Graphics.Blit (source, destination, dysphoriaMaterial);
	}
}
