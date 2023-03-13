using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Grayscale : MonoBehaviour
{
    Camera cam;

	private Shader grayscaleShader = null;
	private Material grayscaleMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        grayscaleShader = Shader.Find("MyShaders/Grayscale");
        grayscaleMaterial = CheckShader(grayscaleShader, grayscaleMaterial);

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
        DestroyImmediate(grayscaleMaterial);
#else
        Destroy(grayscaleMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        grayscaleMaterial.SetColor("_color", Color.black);

        Graphics.Blit (source, destination, grayscaleMaterial);
	}
}
