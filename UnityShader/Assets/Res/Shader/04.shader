// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/04"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Color", Color) = (1,0,0,1)
        _Gloss ("Gloss", Range(8.0,256.0)) = 8.0
        _SpecTex ("Spec",2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        // 漫反射 + 镜面高光 逐像素
        
        // 漫反射公式   ( n * l ) * Mdiffuse * CLight
        // 镜面公式    (n*h)^gloss * Mdiffuse * CLight
        // saturate(x) 函数 将x限定在 [0,1] 标量 和 向量 都支持 
        
        Pass
        {
            LOD 100
            
            Tags { "LightMode"="ForwardBase" }

            Name "VertexLit"
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uvMain : TEXCOORD0;
                float2 uvSpec : TEXCOORD1;

                float3 worldNormal : TEXCOORD2;
                float3 worldVertex : TEXCOORD3;
                
                float4 vertex : SV_POSITION;

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            sampler2D _SpecTex;
            float4 _SpecTex_ST;
            
            float _Gloss;
            fixed4 _MainColor;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvSpec = TRANSFORM_TEX(v.uv, _SpecTex);
                o.worldNormal = normalize(mul(v.normal,unity_WorldToObject));
                o.worldVertex = mul(unity_ObjectToWorld,v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainTexColor = tex2D(_MainTex, i.uvMain);
                fixed4 specTexColor = tex2D(_SpecTex, i.uvSpec);
                fixed3 lightColor = _LightColor0.rgb;

                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 reflectDir = normalize(reflect(-worldLightDir,i.worldNormal));
                fixed3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldVertex);
                
                fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 difuseColor = saturate(dot(i.worldNormal,worldLightDir)) * mainTexColor * lightColor * _MainColor;
                fixed3 specColor = pow(saturate(dot(eyeDir,reflectDir)),_Gloss) * specTexColor * lightColor * _MainColor;

                
                return fixed4(ambientColor + difuseColor + specColor,1.0);
            }
            ENDCG
        }
    }
}
