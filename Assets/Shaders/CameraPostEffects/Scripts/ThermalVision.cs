using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class ThermalVision : MonoBehaviour
{
    public Color _shadow = Color.gray;
    public Color _volume = Color.green;
    public Color _global = Color.magenta;
    [Range(0.0f, 1.0f)]
    public float _threshold = 0.5f;

    public bool _invert = false;

    Camera cam;

    private Shader thermalVisionShader = null;
    private Material thermalVisionMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        thermalVisionShader = Shader.Find("MyShaders/ThermalVision");
        thermalVisionMaterial = CheckShader(thermalVisionShader, thermalVisionMaterial);

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
        DestroyImmediate(thermalVisionMaterial);
#else
        Destroy(thermalVisionMaterial);
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
            thermalVisionMaterial.EnableKeyword("INVERT");
        else
            thermalVisionMaterial.DisableKeyword("INVERT");

        thermalVisionMaterial.SetColor("_shadow", _shadow);
        thermalVisionMaterial.SetColor("_volume", _volume);
        thermalVisionMaterial.SetColor("_global", _global);
        thermalVisionMaterial.SetFloat("_threshold", _threshold);

        Graphics.Blit (source, destination, thermalVisionMaterial);
	}
}
