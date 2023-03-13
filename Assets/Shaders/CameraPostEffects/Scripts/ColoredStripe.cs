using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class ColoredStripe : MonoBehaviour
{
    [Range(0.0f, 2.0f)]
    public float _threshold = 1.0f;
    [Range(0.0f, 1.0f)]
    public float _size = 0.5f;
    public bool _invert = false;

    public enum myStripes { Horizontal, Vertical, Dot };
    public myStripes _stripes;
    private int _shape;
    
    public Color _color = Color.gray;

    private Camera cam;

    private Shader coloredStripeShader = null;
    private Material coloredStripeMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        coloredStripeShader = Shader.Find("MyShaders/ColoredStripe");
        coloredStripeMaterial = CheckShader(coloredStripeShader, coloredStripeMaterial);

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
        DestroyImmediate(coloredStripeMaterial);
#else
        Destroy(coloredStripeMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        cam = GetComponent<Camera>();
        cam.backgroundColor = _color;

        if (_stripes == myStripes.Horizontal)
            _shape = 0;
        if (_stripes == myStripes.Vertical)
            _shape = 1;
        if (_stripes == myStripes.Dot)
            _shape = 2;

        int _resX = Screen.width;
        int _resY = Screen.height;

        if (_invert == true)
            coloredStripeMaterial.EnableKeyword("INVERT");
        else
            coloredStripeMaterial.DisableKeyword("INVERT");

        coloredStripeMaterial.SetFloat("_threshold", _threshold);
        coloredStripeMaterial.SetFloat("_size", 1 - _size);
        coloredStripeMaterial.SetInt("_shape", _shape);
        coloredStripeMaterial.SetInt("_resX", _resX);
        coloredStripeMaterial.SetInt("_resY", _resY);
           
        Graphics.Blit (source, destination, coloredStripeMaterial);
	}
}
