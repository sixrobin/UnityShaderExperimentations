Shader "DM/DM_PostProcess_CRT"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        ZTest Always
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform float _Curvature;
            uniform float _VignetteWidth;
            uniform float _ScanlinesMultiplier;
            uniform float3 _RGBMultiplier;

            fixed4 frag(v2f_img i) : SV_Target
            {
                // Curvature.
                float2 uv_curved = i.uv * 2 - 1; // Normalize to [-1;1].
                float offset = uv_curved / _Curvature;
                uv_curved += uv_curved * offset * offset;
                uv_curved = uv_curved * 0.5 + 0.5; // Normalize back to [0;1].

                // Avoid repeating screen.
                if (uv_curved.x < 0 || uv_curved.x > 1 || uv_curved.y < 0 || uv_curved.y > 1)
                    return float4(0, 0, 0, 1);

                // Vignette.
                float2 uv_vignette = uv_curved * 2 - 1; // Normalize to [-1;1].
                float2 vignette = _VignetteWidth / _ScreenParams.xy;
                vignette = smoothstep(0, vignette, 1 - abs(uv_vignette));
                vignette = saturate(vignette);

                // Scanline.
                float scanline = uv_curved.y * _ScreenParams.y * _ScanlinesMultiplier;

                // Final color computation.
                fixed4 color = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(uv_curved, _MainTex_ST)); // Sample.
                color *= vignette.x * vignette.y; // Apply vignette.
                color.g *= (sin(scanline) + 1) * _RGBMultiplier.g + 1; // Scanline G (sin).
                color.r *= (cos(scanline) + 1) * _RGBMultiplier.r + 1; // Scanline R (cos).
                color.b *= (cos(scanline) + 1) * _RGBMultiplier.b + 1; // Scanline B (cos).
                
                return color;
            }
            
            ENDCG
        }
    }
}
