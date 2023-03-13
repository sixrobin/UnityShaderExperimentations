using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Lens : MonoBehaviour
{
    [Range(-5.0f, 5.0f)]
    public float _lens = 1.0f;
    [Range(-5.0f, 5.0f)]
    public float _cubic = 0.5f;

    Camera cam;

	private Shader lensShader = null;
	private Material lensMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        lensShader = Shader.Find("MyShaders/Lens");
        lensMaterial = CheckShader(lensShader, lensMaterial);

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
        DestroyImmediate(lensMaterial);
#else
        Destroy(lensMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        lensMaterial.SetFloat ("_lens", _lens);
	    lensMaterial.SetFloat ("_cubic", _cubic);

		Graphics.Blit (source, destination, lensMaterial);
	}
}
