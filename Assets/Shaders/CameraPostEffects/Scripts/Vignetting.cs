using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Vignetting : MonoBehaviour
{
    [Range(0.0f, 1.0f)]
    public float _vignette = 0.3f;

    Camera cam;

    private Shader vignettingShader = null;
    private Material vignettingMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        vignettingShader = Shader.Find("MyShaders/Vignetting");
        vignettingMaterial = CheckShader(vignettingShader, vignettingMaterial);

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
        DestroyImmediate(vignettingMaterial);
#else
        Destroy(vignettingMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        vignettingMaterial.SetFloat("_vignette", _vignette);

        Graphics.Blit (source, destination, vignettingMaterial);
	}
}
