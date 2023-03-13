using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class SimpleAberration : MonoBehaviour
{
    [Range(0.0f, 1.0f)]
    public float _aberration = 0.5f;

    Camera cam;

    private Shader simpleAberrationShader = null;
    private Material simpleAberrationMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        simpleAberrationShader = Shader.Find("MyShaders/SimpleAberration");
        simpleAberrationMaterial = CheckShader(simpleAberrationShader, simpleAberrationMaterial);

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
        DestroyImmediate(simpleAberrationMaterial);
#else
        Destroy(simpleAberrationMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        simpleAberrationMaterial.SetFloat("_aberration", _aberration);

        Graphics.Blit (source, destination, simpleAberrationMaterial);
	}
}
