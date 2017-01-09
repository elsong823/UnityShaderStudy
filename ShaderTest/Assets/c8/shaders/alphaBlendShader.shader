Shader "MyShader/c8/alphaBlendShader"
{

	Properties
	{	
		_TransTex("TransTex", 2D) = "white"{}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_AlphaScale("Alpha Scale", Range(0, 1)) = 1.0
	}

	SubShader
	{	
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha
//			Cull off
			CGPROGRAM

			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _TransTex;
			float4 _TransTex_ST;
			fixed4 _Color;
			float _AlphaScale;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f Vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord.xy * _TransTex_ST.xy + _TransTex_ST.zw;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(_Object2World, v.vertex).xyz;

				return o;
			}

			fixed4 Frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize( i.worldNormal );
				fixed3 worldLight = normalize( UnityWorldSpaceLightDir( i.worldPos ) );
				fixed3 worldView = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
				fixed3 worldHalf = normalize( worldLight + worldView );

				fixed4 texColor = tex2D(_TransTex, i.uv);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * texColor.rgb * _Color;

				fixed3 diffuse = texColor.rgb * saturate( dot(worldLight, worldNormal) ) * _Color * _LightColor0;

				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
			}


			ENDCG
		}
	}

	Fallback "Transparent/VertexLite"
	
}