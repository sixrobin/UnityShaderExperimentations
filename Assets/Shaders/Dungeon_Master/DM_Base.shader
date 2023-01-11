Shader "DM/DM_Base"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _DepthMultiplier ("Depth Multiplier", float) = 0.1
        _DepthSmoothCenter ("Depth Smooth Center", Range(0, 1)) = 0.5
        _DepthSmoothValue ("Depth Smooth Value", Range(0, 1)) = 0.2
        _DepthColor ("Depth Color", Color) = (0, 0, 0, 1)
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        
        LOD 100

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float2 uv     : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float2 uv           : TEXCOORD0;
                float4 vertex       : SV_POSITION;
                float4 screen_space : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
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

                // Compute depth.
                float depth = i.screen_space.z;
                depth *= _DepthMultiplier;
                depth = smoothstep(_DepthSmoothCenter - _DepthSmoothValue, _DepthSmoothCenter + _DepthSmoothValue, depth);
                
                return (main_color * _Color * depth) + (_DepthColor * (1 - depth));
            }
            
            ENDCG
        }
    }
}
