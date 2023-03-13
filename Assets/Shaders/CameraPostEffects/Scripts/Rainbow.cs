using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Rainbow : MonoBehaviour
{
    [Range(0.01f, 1.0f)]
    public float _size = 0.2f;
    [Range(0.1f, 5.0f)]
    public float _saturation = 1;
    [Range(0.0f, 1.0f)]
    public float _variation = 0.5f;
    [Range(-10.0f, 10.0f)]
    public float _speed = 1.0f;

    public bool _lolipop = false;

    public enum myAxis { Horizontal, Vertical, PatchworkH, PatchworkV };
    public myAxis axis;
    int _axis = 0;

    Camera cam;

    private Shader rainbowShader = null;
    private Material rainbowMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        rainbowShader = Shader.Find("MyShaders/Rainbow");
        rainbowMaterial = CheckShader(rainbowShader, rainbowMaterial);

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
        DestroyImmediate(rainbowMaterial);
#else
        Destroy(rainbowMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        if (axis == myAxis.Horizontal)
            _axis = 0;
        if (axis == myAxis.Vertical)
            _axis = 1;
        if (axis == myAxis.PatchworkH)
            _axis = 2;
        if (axis == myAxis.PatchworkV)
            _axis = 3;

        if (_lolipop == true)
            rainbowMaterial.EnableKeyword("LOLIPOP");
        else
            rainbowMaterial.DisableKeyword("LOLIPOP");
            
        rainbowMaterial.SetFloat("_size", 1 - _size);
        rainbowMaterial.SetFloat("_saturation", _saturation);
        rainbowMaterial.SetFloat("_variation", _variation);
        rainbowMaterial.SetFloat ("_speed", _speed);
        rainbowMaterial.SetInt("_axis", _axis);

        Graphics.Blit (source, destination, rainbowMaterial);
	}
}
