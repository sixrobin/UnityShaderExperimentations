Shader "Oil Painting"
{
    Properties
    {
        _PaintTexture ("Paint Texture", 2D) = "white" {}
        _ColorRamp ("Color Ramp", 2D) = "white" {}
        _PaintSmoothing ("Paint Smoothing", Range(0, 1)) = 0.5
        
        _LightIntensity ("Light Intensity", Range(0, 1)) = 1
        _AmbientColorIntensity ("Ambient Color Intensity", Range(0, 1)) = 1
        _MinLightValue ("Min Light Value", Range(0, 1)) = 0
        
        [Header(SPECULAR)]
        _SpecularIntensity ("Specular Intensity", Range(0, 1)) = 1
        _SpecularPower ("Specular Power", Range(1, 128)) = 64
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "LightMode"="ForwardBase"
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
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex       : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 normal_world : TEXCOORD1;
                float3 vertex_world : TEXCOORD2;
            };

            sampler2D _PaintTexture;
            float4 _PaintTexture_ST;
            sampler2D _ColorRamp;
            float _PaintSmoothing;
            
            float _LightIntensity;
            uniform float4 _LightColor0;
            float _AmbientColorIntensity;
            float _MinLightValue;

            float _SpecularIntensity;
            float _SpecularPower;
            
            float3 lambert(float3 reflection_color, float light_intensity, float3 normal, float3 light_direction)
            {
                return reflection_color * light_intensity * max(0, dot(normal, light_direction));
            }

            float3 specular(float3 reflection_color, float intensity, float3 normal, float3 light_direction, float3 vertex_world, float power)
            {
                float3 view_direction = normalize(_WorldSpaceCameraPos - vertex_world);
                float3 halfway = normalize(light_direction + view_direction);
                return reflection_color * intensity * pow(max(0, dot(normalize(normal), halfway)), power);
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _PaintTexture);
                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz;
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 normal = (i.normal_world + 1) * 0.5;
                float3 lightColor = _LightColor0.rgb;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

                float paintIntensity = tex2D(_PaintTexture, i.uv); // TODO: Tri-planar projection.

                float diffuse = lambert(lightColor, _LightIntensity, normal, lightDirection).r;

                float3 specularHighlight = specular(lightColor, _SpecularIntensity, i.normal_world, lightDirection, i.vertex_world, _SpecularPower);

                diffuse = smoothstep(paintIntensity - _PaintSmoothing, paintIntensity + _PaintSmoothing, diffuse);
                diffuse = max(diffuse, _MinLightValue);
                // TODO: Apply specular.

                float4 paintColor = tex2D(_ColorRamp, float2(diffuse.x, 0));

                return paintColor;
                
                float4 color = float4(1, 1, 1, 1);
                color.rgb *= diffuse;
                color.rgb += UNITY_LIGHTMODEL_AMBIENT * _AmbientColorIntensity * (1 - diffuse);
                color.rgb += specularHighlight;
                
                return color;
            }
            
            ENDCG
        }
    }
}
