Shader "USB/PSX"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_VertexSnapPrecisionX ("Vertex Snap Precision X", Float) = 160
		_VertexSnapPrecisionY ("Vertex Snap Precision Y", Float) = 120
	}
	
	SubShader
	{
		Tags
		{
			"Queue"="Geometry"
			"RenderType"="Opaque"
		}
		
		LOD 200

		Pass
		{
			Lighting On
			
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos      : SV_POSITION;
				fixed4 color    : COLOR0;
				fixed4 colorFog : COLOR1;
				float2 uv       : TEXCOORD0;
				float3 normal   : TEXCOORD1;
			};
			
			uniform half4 unity_FogStart;
			uniform half4 unity_FogEnd;
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _VertexSnapPrecisionX;
			float _VertexSnapPrecisionY;

			v2f vert(appdata_full v)
			{
				v2f o;

				float distance = length(mul(UNITY_MATRIX_MV, v.vertex));

				// Vertex snapping.
				float4 clipPos = UnityObjectToClipPos(v.vertex);
				float4 vertex = clipPos;
				vertex.xyz = clipPos.xyz / clipPos.w;
				vertex.x = floor(_VertexSnapPrecisionX * vertex.x) / _VertexSnapPrecisionX;
				vertex.y = floor(_VertexSnapPrecisionY * vertex.y) / _VertexSnapPrecisionY;
				vertex.xyz *= clipPos.w;
				o.pos = vertex;

				// Vertex lighting.
				o.color = v.color * UNITY_LIGHTMODEL_AMBIENT;

				// Affine Texture Mapping.
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv *= distance + vertex.w * (UNITY_LIGHTMODEL_AMBIENT.a * 8) / distance / 2;

				// Fog.
				float fogDensity = (unity_FogEnd - distance) / (unity_FogEnd - unity_FogStart);
				o.colorFog = fixed4(unity_FogColor.rgb, saturate(fogDensity));

				// Normal.
				o.normal = float3(distance + vertex.w * (UNITY_LIGHTMODEL_AMBIENT.a * 8) / distance / 2, fogDensity, 1);
				
				// Clip far polygons.
				if (distance > unity_FogStart.z + unity_FogColor.a * 255)
					o.pos.w = 0;
				
				return o;
			}

			float4 frag(v2f i) : COLOR
			{
				fixed4 color = tex2D(_MainTex, i.uv / i.normal.r) * i.color;
				color *= i.colorFog.a;
				color.rgb += i.colorFog.rgb * (1 - i.colorFog.a);
				return color;
			}
			
			ENDCG
		}
	}
}