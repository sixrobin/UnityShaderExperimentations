Shader "MyShaders/Impression" {

	Properties 
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_mapTexture ("Map Texture", 2D) = "white" {}
		_tilesX ("X OnScreen Characters", int) = 160
		_tilesY ("Y OnScreen Characters", int) = 90
		_threshold ("Threshold", float) = 0.5
	}

	CGINCLUDE
	#include "UnityCG.cginc"
			
	struct v2f 
	{
		float4 vertex   : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
			
	sampler2D _MainTex;		
	sampler2D _mapTexture;			
	int _tilesX;
	int _tilesY;
	float _threshold;
			
	float4 frag(v2f i) : COLOR 
	{
		float4 sum = tex2D(_MainTex, i.uv);
		float lum = clamp(((0.31 * sum.r) + (0.59 * sum.g) + (0.11 * sum.b)) / _threshold, 0, 1);
				
		float2 imp = float2(frac(i.uv.x * _tilesX), frac(i.uv.y * _tilesY));
		imp.x = (imp.x + floor(lum));

		float4 col = tex2D(_mapTexture, imp);

		float4 finalImp = lerp(sum * (lum + 7) / 10, sum, step(0.5, col.r));
				
		return fixed4(finalImp);
	}
	
	ENDCG

	SubShader {
		Pass{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			ENDCG
		}
	}
	Fallback off
}
