using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Pendulum : MonoBehaviour
{
    [Range(0.0f, 2.0f)]
    public float _speed = 1.0f;
    [Range(0.0f, 5.0f)]
    public float _aberration = 1.0f;

    Camera cam;

    private Shader pendulumShader = null;
    private Material pendulumMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        pendulumShader = Shader.Find("MyShaders/Pendulum");
        pendulumMaterial = CheckShader(pendulumShader, pendulumMaterial);

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
        DestroyImmediate(pendulumMaterial);
#else
        Destroy(pendulumMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        pendulumMaterial.SetFloat("_speed", _speed);
        pendulumMaterial.SetFloat("_aberration", _aberration);

        Graphics.Blit (source, destination,pendulumMaterial);
	}
}
