using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Fisheye : MonoBehaviour
{
    [Range(0.0f, 1.0f)]
    public float _intensityX = 0.25f;
    [Range(0.0f, 1.0f)]
    public float _intensityY = 0.25f;

    Camera cam;

    private Shader fisheyeShader = null;
    private Material fisheyeMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        fisheyeShader = Shader.Find("MyShaders/Fisheye");
        fisheyeMaterial = CheckShader(fisheyeShader, fisheyeMaterial);

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
        DestroyImmediate(fisheyeMaterial);
#else
        Destroy(fisheyeMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

		fisheyeMaterial.SetFloat("_intensityX", _intensityX/10);
        fisheyeMaterial.SetFloat("_intensityY", _intensityY/10);
 
        Graphics.Blit (source, destination, fisheyeMaterial);
    }
}
