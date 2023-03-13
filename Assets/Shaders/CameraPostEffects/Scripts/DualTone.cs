using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class DualTone : MonoBehaviour
{
	public Color _volume = Color.blue;
	public Color _global = Color.red;

    [Range(0.0f, 1.0f)]
	public float _threshold = 0.5f;

    public bool _invert;

    Camera cam;

	private Shader dualToneShader = null;
	private Material dualToneMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        dualToneShader = Shader.Find("MyShaders/DualTone");
        dualToneMaterial = CheckShader(dualToneShader, dualToneMaterial);

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
        DestroyImmediate(dualToneMaterial);
#else
        Destroy(dualToneMaterial);
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
            dualToneMaterial.EnableKeyword("INVERT");
        else
            dualToneMaterial.DisableKeyword("INVERT");

        dualToneMaterial.SetColor ("_volume", _volume);
	    dualToneMaterial.SetColor ("_global", _global);
		dualToneMaterial.SetFloat ("_threshold", _threshold);

		Graphics.Blit (source, destination, dualToneMaterial);
	}
}
