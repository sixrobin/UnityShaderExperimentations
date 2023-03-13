using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class SSAA : MonoBehaviour
{
    public enum myMode { Roated, Grid };
    public myMode mode;
    int _mode = 0;

    public enum mySize { Low, Medium, High };
    public mySize size;
    int _size = 0;

    Camera cam;

    private Shader ssaaShader = null;
    private Material ssaaMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        ssaaShader = Shader.Find("MyShaders/SSAA");
        ssaaMaterial = CheckShader(ssaaShader, ssaaMaterial);

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
        DestroyImmediate(ssaaMaterial);
#else
        Destroy(ssaaMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        if (mode == myMode.Roated)
            _mode = 0;
        if (mode == myMode.Grid)
            _mode = 1;

        if (size == mySize.Low)
            _size = 512;
        if (size == mySize.Medium)
            _size = 1024;
        if (size == mySize.High)
            _size = 2048;

        ssaaMaterial.SetInt("_mode", _mode);
        ssaaMaterial.SetInt("_size", _size);

        Graphics.Blit (source, destination, ssaaMaterial);
	}
}
