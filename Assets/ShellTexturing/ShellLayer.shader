Shader "USB/Shell Layer"
{
    Properties
    {
        _Mask ("Mask", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
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
            };

            sampler2D _Mask;
            float4 _Mask_ST;
            float4 _Mask_TexelSize;
            float4 _Color;
            float _Radius;

            float _ShellIndex;
            float _ShellsCount;
            float _StepMin;
            float _StepMax;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float heightPercentage = _ShellIndex / _ShellsCount;
                float centerDistance = length((frac(i.uv / _Mask_TexelSize.xy) - 0.5) * 2);
                fixed shellRandomValue = lerp(_StepMin, _StepMax, tex2D(_Mask, i.uv).x);

                if (centerDistance > _Radius * (shellRandomValue - heightPercentage) && _ShellIndex > 0)
                    discard;
                
                return _Color;
            }
            
            ENDCG
        }
    }
}
