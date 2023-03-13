using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Posterization : MonoBehaviour
{
    [Range(1, 20)]
    public int _amount = 6;
    [Range(0.01f, 1.0f)]
    public float _global = 0.2f;

    Camera cam;

	private Shader posterizationShader = null;
	private Material posterizationMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        posterizationShader = Shader.Find("MyShaders/Posterization");
        posterizationMaterial = CheckShader(posterizationShader, posterizationMaterial);

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
        DestroyImmediate(posterizationMaterial);
#else
        Destroy(posterizationMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

		posterizationMaterial.SetFloat ("_amount",_amount);
		posterizationMaterial.SetFloat ("_global", 1 - _global);

		Graphics.Blit (source, destination, posterizationMaterial);
	}
}
