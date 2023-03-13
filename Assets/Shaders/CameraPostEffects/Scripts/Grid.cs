using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Grid : MonoBehaviour
{
    [Range(1, 50)]
    public int _scaleX = 10;
    [Range(1, 50)]
    public int _scaleY = 10;

    public Color _gridColor = Color.black;

    Camera cam;

    private Shader gridShader = null;
    private Material gridMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        gridShader = Shader.Find("MyShaders/Grid");
        gridMaterial = CheckShader(gridShader, gridMaterial);

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
        DestroyImmediate(gridMaterial);
#else
        Destroy(gridMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        gridMaterial.SetInt("_scaleX", _scaleX);
        gridMaterial.SetInt("_scaleY", _scaleY);
        gridMaterial.SetColor("_gridColor", _gridColor);

        Graphics.Blit (source, destination, gridMaterial);
	}
}
