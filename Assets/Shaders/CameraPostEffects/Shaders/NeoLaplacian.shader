// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/NeoLaplacian" {
	
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_amplitude("Amplitude", float) = 0
		_size("Dot Size", float) = 0
		_resX("ResolutionX", int) = 0
		_resY("ResolutionY", int) = 0
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float _amplitude;
	float _size;
	int _resX;
	int _resY;

	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float4 sum = (float4)0;
		sum = -9 * tex2D(_MainTex, i.uv);

		float2 offsets[9] = 
		{  
			float2(-1, -1),
			float2(-1, 0),
			float2(-1, 1),
			float2(0, -1),
			float2(0, 0),  
			float2(0, 1),  
			float2(1, -1),
			float2(1, 0),
			float2(1, 1)
		}; 

		for (int j = 0; j < 9; j++)
			sum += tex2D(_MainTex, i.uv + _amplitude/10 * offsets[j]);

		sum.rgb += cos(i.uv.x * _resX * _size) * 0.33;
		sum.rgb += cos(i.uv.y * _resY * _size) * 0.33;
		sum.rgb *= dot(sum.xyz * sum.rgb, 0.5f);

#ifdef INVERT
		sum = 1 - sum;
#endif
		return fixed4(sum); 
	}

	ENDCG 
	
	Subshader 
	{
		Pass 
		{
			ZTest Always 
			Cull Off 
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature INVERT
			ENDCG
		}  
	}
	Fallback off	
}
