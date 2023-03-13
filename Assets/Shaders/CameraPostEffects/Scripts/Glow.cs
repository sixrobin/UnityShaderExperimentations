using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Glow : MonoBehaviour
{
    [Range(0.0f, 1.0f)]
    public float _exposure = 0.5f;
    [Range(0.0f, 1.0f)]
    public float _bright = 0.5f;
    [Range(0.0f, 1.0f)]
    public float _global = 0.5f;
    [Range(0.0f, 4.0f)]
    public float _intensity = 2;

    Camera cam;

    private Shader glowShader = null;
    private Material glowMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        glowShader = Shader.Find("MyShaders/Glow");
        glowMaterial = CheckShader(glowShader, glowMaterial);

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
        DestroyImmediate(glowMaterial);
#else
        Destroy(glowMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        glowMaterial.SetFloat("_exposure", _exposure);
        glowMaterial.SetFloat("_bright", 1 - _bright);
        glowMaterial.SetFloat("_global", _global);
        glowMaterial.SetFloat("_intensity", 5 - _intensity);

        Graphics.Blit (source, destination, glowMaterial);
	}
}
