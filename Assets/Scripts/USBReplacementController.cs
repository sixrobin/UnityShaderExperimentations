using UnityEngine;

[ExecuteInEditMode]
public class USBReplacementController : MonoBehaviour
{
    public Shader m_replacementShader;

    private void OnEnable()
    {
        if (this.m_replacementShader != null)
        {
            this.GetComponent<Camera>().SetReplacementShader(this.m_replacementShader, "RenderType");
        }
    }

    private void OnDisable()
    {
        this.GetComponent<Camera>().ResetReplacementShader();
    }
}
