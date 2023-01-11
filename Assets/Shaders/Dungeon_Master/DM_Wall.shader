Shader "DM/DM_Wall"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PPU ("PPU", int) = 64
        _GradientScale ("Gradient Scale", Range(0, 1)) = 0.5
        _GradientColor ("Gradient Color", Color) = (0, 0, 0, 1)
        _GradientMask ("Gradient Mask", 2D) = "white" {}
        _GradientMaskStrength ("Gradient Mask Strength", Range(0, 1)) = 0.5
        _DepthMultiplier ("Depth Multiplier", float) = 0.1
        _DepthSmoothCenter ("Depth Smooth Center", Range(0, 1)) = 0.5
        _DepthSmoothValue ("Depth Smooth Value", Range(0, 1)) = 0.2
        _DepthColor ("Depth Color", Color) = (0, 0, 0, 1)
    }
    
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }
        
        Cull Off
        LOD 100

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv     : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screen_space : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
            int _PPU;
            float _GradientScale;
            float4 _GradientColor;
            sampler2D _GradientMask;
            float4 _GradientMask_ST;
            float _GradientMaskStrength;
            half _DepthMultiplier;
            half _DepthSmoothCenter;
            half _DepthSmoothValue;
            float4 _DepthColor;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screen_space = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 main_color = tex2D(_MainTex, i.uv);
                fixed4 gradient_mask = tex2D(_GradientMask, i.uv);
                
                // Compute depth.
                float depth = i.screen_space.z;
                depth *= _DepthMultiplier;
                depth = smoothstep(_DepthSmoothCenter - _DepthSmoothValue, _DepthSmoothCenter + _DepthSmoothValue, depth);
                // depth = floor(depth * _PPU) / _PPU;
                
                // Pixelate uv.
                float2 uv_pixelated = floor(i.uv * _PPU) / _PPU;
                
                float upward_gradient_mask = uv_pixelated.y;
                upward_gradient_mask = smoothstep(_GradientScale, -_GradientScale, upward_gradient_mask) * 2 * _GradientColor.a;
                upward_gradient_mask *= saturate(gradient_mask + (1 - _GradientMaskStrength));

                float4 upward_gradient_color = upward_gradient_mask * _GradientColor;

                return (main_color * (1 - upward_gradient_mask) + upward_gradient_color) * depth + (_DepthColor * (1 - depth));
            }
            
            ENDCG
        }
    }
}
