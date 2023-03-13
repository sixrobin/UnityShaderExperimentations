using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Pong : MonoBehaviour
{
    public Color _color = Color.white;

    [Range(2, 20)]
    public int _scale = 10;
    [Range(0.0f, 1.0f)]
    public float _threshold = 0.5f;

    Camera cam;

    private Shader pongShader = null;
    private Material pongMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        pongShader = Shader.Find("MyShaders/Pong");
        pongMaterial = CheckShader(pongShader, pongMaterial);

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
        DestroyImmediate(pongMaterial);
#else
        Destroy(pongMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        pongMaterial.SetColor("_color", _color);
        pongMaterial.SetInt("_scale", _scale);
        pongMaterial.SetFloat("_threshold", _threshold);

        Graphics.Blit (source, destination, pongMaterial);
	}
}
