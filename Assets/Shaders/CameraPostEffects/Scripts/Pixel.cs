using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Pixel : MonoBehaviour
{
    [Range(2, 20)]
    public int _scale = 10;

    public Color _gridColor = Color.black;

    Camera cam;

    private Shader pixelShader = null;
    private Material pixelMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        pixelShader = Shader.Find("MyShaders/Pixel");
        pixelMaterial = CheckShader(pixelShader, pixelMaterial);

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
        DestroyImmediate(pixelMaterial);
#else
        Destroy(pixelMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        pixelMaterial.SetInt("_scale", _scale);
        pixelMaterial.SetColor("_gridColor", _gridColor);

        Graphics.Blit (source, destination, pixelMaterial);
	}
}
