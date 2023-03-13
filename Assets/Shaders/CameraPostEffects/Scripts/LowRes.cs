using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]

public class LowRes : MonoBehaviour
{
    public enum myRes { QQVGA, HQVGA, QVGA, WQVGA, HVGA, VGA };
    public myRes resolution;

    private int _resX;
    private int _resY;

    Camera cam;

    private Shader lowResShader = null;
    private Material lowResMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        lowResShader = Shader.Find("MyShaders/LowRes");
        lowResMaterial = CheckShader(lowResShader, lowResMaterial);

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
        DestroyImmediate(lowResMaterial);
#else
        Destroy(lowResMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
	    }
			
        if (resolution == myRes.QQVGA)
        {
            _resX = 160;
            _resY = 120;
        }

        if (resolution == myRes.HQVGA)
        {
            _resX = 240;
            _resY = 160;
        }

        if (resolution == myRes.QVGA)
        {
            _resX = 320;
            _resY = 240;
        }

        if (resolution == myRes.WQVGA)
        {
            _resX = 400;
            _resY = 240;
        }

        if (resolution == myRes.HVGA)
        {
            _resX = 480;
            _resY = 320;
        }

        if (resolution == myRes.VGA)
        {
            _resX = 640;
            _resY = 480;
        }

        lowResMaterial.SetInt ("_resX", _resX);
		lowResMaterial.SetInt ("_resY", _resY);

		Graphics.Blit (source, destination, lowResMaterial);
	}
}
