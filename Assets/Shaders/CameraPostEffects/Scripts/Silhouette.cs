using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Silhouette : MonoBehaviour
{
    public bool _invert = false;

    Camera cam;

    private Shader silhouetteShader = null;
    private Material silhouetteMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        silhouetteShader = Shader.Find("MyShaders/Silhouette");
        silhouetteMaterial = CheckShader(silhouetteShader, silhouetteMaterial);

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
        cam.renderingPath = RenderingPath.VertexLit;
        cam.clearFlags = CameraClearFlags.SolidColor;
        cam.backgroundColor = Color.white;

        m = new Material(s);
        m.hideFlags = HideFlags.DontSave;

        if (s.isSupported && m && m.shader == s)
            return m;

        return m;
    }

    void OnDestroy()
    {
#if UNITY_EDITOR
        DestroyImmediate(silhouetteMaterial);
#else
        Destroy(silhouetteMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}
        
        if (_invert == true)
            silhouetteMaterial.EnableKeyword("INVERT");
        else
            silhouetteMaterial.DisableKeyword("INVERT");

        Graphics.Blit (source, destination, silhouetteMaterial);
	}
}
