float hachage(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123); }

vec2 ondeLogGerstner(vec2 posLog, vec2 dir, float longueurOnde, float amplitude, float vitesse, float temps) {
    float k = 6.2831853 / longueurOnde;
    float phase = k * dot(dir, posLog) - vitesse * temps;
    float c = cos(phase);
    float s = sin(phase);
    return vec2(
        dir.x * amplitude * c,
        dir.y * amplitude * s
    );
}

vec3 calculerCouleur(vec2 coordonneesLisses, float tempsValeur)
{
    float tempsRalenti = tempsValeur * 0.3;

    float periodeEffet = 2.5;
    float tempsEffet = tempsValeur / periodeEffet;
    float graineActuelle = floor(tempsEffet);
    float graineSuivante = graineActuelle + 1.0;

    float declencheurActuel = hachage(vec2(graineActuelle, 1.234));
    float declencheurSuivant = hachage(vec2(graineSuivante, 1.234));

    float phaseBrute = fract(tempsEffet);
    float morphismeEffet = smoothstep(0.0, 0.3, phaseBrute) * (1.0 - smoothstep(0.7, 1.0, phaseBrute));

    float actifActuel = step(0.6, declencheurActuel);
    float actifSuivant = step(0.6, declencheurSuivant);

    float typeEffetActuel = floor(declencheurActuel * 4.0);
    float typeEffetSuivant = floor(declencheurSuivant * 4.0);

    float cycleMorphisme = sin(tempsValeur * 0.5) * 0.5 + 0.5;
    float formeMorphisme = smoothstep(0.0, 1.0, cycleMorphisme);

    float rayon = length(coordonneesLisses);
    float angle = atan(coordonneesLisses.y, coordonneesLisses.x);

    float logRayonBase = log(rayon + 1e-5);
    vec2 posLogPolaire = vec2(logRayonBase, sin(angle));

    vec2 deplacementGerstner = vec2(0.0);
    deplacementGerstner += ondeLogGerstner(posLogPolaire, normalize(vec2(1.0, 0.5)), 1.5, 0.12, 2.0, tempsValeur);
    deplacementGerstner += ondeLogGerstner(posLogPolaire, normalize(vec2(-0.7, 0.8)), 0.8, 0.06, 3.1, tempsValeur);
    deplacementGerstner += ondeLogGerstner(posLogPolaire, normalize(vec2(0.3, -1.2)), 0.4, 0.03, 4.5, tempsValeur);

    rayon = exp(logRayonBase + deplacementGerstner.x);
    angle += deplacementGerstner.y;

    float distorsionOndulationActuelle = (abs(typeEffetActuel - 0.0) < 0.1) ? sin(rayon * 30.0 - tempsValeur * 10.0) * 0.08 : 0.0;
    float distorsionOndulationSuivante = (abs(typeEffetSuivant - 0.0) < 0.1) ? sin(rayon * 30.0 - tempsValeur * 10.0) * 0.08 : 0.0;
    float distorsionOndulation = mix(0.0, mix(distorsionOndulationActuelle, distorsionOndulationSuivante, phaseBrute), morphismeEffet * max(actifActuel, actifSuivant));
    rayon += distorsionOndulation;

    float torsionOndulationActuelle = (abs(typeEffetActuel - 0.0) < 0.1) ? sin(log(rayon + 1e-5) * 10.0) * 0.4 : 0.0;
    float torsionOndulationSuivante = (abs(typeEffetSuivant - 0.0) < 0.1) ? sin(log(rayon + 1e-5) * 10.0) * 0.4 : 0.0;
    float torsionOndulation = mix(0.0, mix(torsionOndulationActuelle, torsionOndulationSuivante, phaseBrute), morphismeEffet * max(actifActuel, actifSuivant));
    angle += torsionOndulation;

    float logRayon = log(rayon + 1e-5);
    float positionU = logRayon - tempsRalenti * 0.5;

    vec3 couleurTotale = vec3(0.0);

    for (int i = 0; i < 6; i++)
    {
        float indiceFloat = float(i);
        float echelle = 2.0 + indiceFloat * 0.5;

        float entierEchelle = floor(echelle);
        float spiraleV = angle / 6.2831853 + positionU * echelle * 0.5;

        vec2 positionPoint = vec2(positionU * echelle, spiraleV * entierEchelle);

        float decalageTrancheActuel = (abs(typeEffetActuel - 1.0) < 0.1) ? sin(positionPoint.y * 6.2831853 * 2.0) * 0.2 : 0.0;
        float decalageTrancheSuivant = (abs(typeEffetSuivant - 1.0) < 0.1) ? sin(positionPoint.y * 6.2831853 * 2.0) * 0.2 : 0.0;
        float decalageTranche = mix(0.0, mix(decalageTrancheActuel, decalageTrancheSuivant, phaseBrute), morphismeEffet * max(actifActuel, actifSuivant));
        positionPoint.x += decalageTranche;

        vec2 cellule = fract(positionPoint) - 0.5;

        float angleCellule = atan(cellule.y, cellule.x);
        float angleGlobal = angleCellule + tempsRalenti + indiceFloat;
        float distanceCentre = length(cellule);

        float nombrePetales = 6.0 + indiceFloat;
        float formePetaleA = 0.5 + 0.5 * cos(angleGlobal * nombrePetales);
        float formePetaleB = abs(cos(angleGlobal * (nombrePetales * 0.5))) * 0.6 + 0.2 * sin(distanceCentre * 10.0 - tempsRalenti);
        float petale = mix(formePetaleA, formePetaleB, formeMorphisme);

        float distanceForme = abs(distanceCentre - petale * 0.25 - 0.05);

        float lueur = 0.01 / (distanceForme + 0.012);

        float lueurOndulationActuelle = (abs(typeEffetActuel - 2.0) < 0.1) ? (1.0 + 3.0 * sin(distanceCentre * 50.0 - tempsValeur * 20.0)) : 1.0;
        float lueurOndulationSuivante = (abs(typeEffetSuivant - 2.0) < 0.1) ? (1.0 + 3.0 * sin(distanceCentre * 50.0 - tempsValeur * 20.0)) : 1.0;
        float lueurOndulation = mix(1.0, mix(lueurOndulationActuelle, lueurOndulationSuivante, phaseBrute), morphismeEffet * max(actifActuel, actifSuivant));
        lueur *= lueurOndulation;
        lueur *= smoothstep(0.0, 0.15, rayon);

        vec3 teinteA = 0.5 + 0.5 * cos(6.2831853 * (indiceFloat * 0.15 + logRayon * 0.1 + vec3(0.0, 0.33, 0.66)) + tempsRalenti);
        vec3 teinteB = 0.5 + 0.5 * sin(6.2831853 * (indiceFloat * 0.2 + logRayon * 0.15 + vec3(0.33, 0.66, 0.0)) - tempsRalenti);
        vec3 teinte = mix(teinteA, teinteB, formeMorphisme);

        vec3 teinteEffetActuelle = (abs(typeEffetActuel - 2.0) < 0.1) ? teinte.gbr : teinte;
        vec3 teinteEffetSuivante = (abs(typeEffetSuivant - 2.0) < 0.1) ? teinte.gbr : teinte;
        teinte = mix(teinte, mix(teinteEffetActuelle, teinteEffetSuivante, phaseBrute), morphismeEffet * max(actifActuel, actifSuivant));

        couleurTotale += teinte * lueur * (1.0 - indiceFloat * 0.12);
    }

    float inversionActuelle = (abs(typeEffetActuel - 3.0) < 0.1 && actifActuel > 0.5) ? 1.0 : 0.0;
    float inversionSuivante = (abs(typeEffetSuivant - 3.0) < 0.1 && actifSuivant > 0.5) ? 1.0 : 0.0;
    float facteurInversion = mix(0.0, mix(inversionActuelle, inversionSuivante, phaseBrute), morphismeEffet);
    couleurTotale = mix(couleurTotale, 1.0 - couleurTotale, facteurInversion);

    float rayonsLumineux = pow(max(0.0, sin(angle * 12.0 + tempsValeur * 2.0)), 8.0) * (0.05 / (rayon + 0.1));
    couleurTotale += vec3(0.4, 0.7, 1.0) * rayonsLumineux;

    couleurTotale += vec3(0.15, 0.4, 0.9) * (0.003 / (rayon + 0.005));

    return couleurTotale;
}

float worldsmith_surface(vec2 coordFragment, vec2 iResolution, float iTime)
{
    vec2 coordonneesLisses = (coordFragment - 0.5 * iResolution.xy) / iResolution.y;
    coordonneesLisses = floor(coordonneesLisses*128) / 128;
    //coordonneesLisses = coordFragment;

    float decalageChromatique = length(coordonneesLisses) * 0.02;
    vec2 directionRayon = normalize(coordonneesLisses + 1e-5);
    
    vec3 couleurResultat;
    couleurResultat.r = calculerCouleur(coordonneesLisses + directionRayon * decalageChromatique, iTime).r;
    //couleurResultat.g = calculerCouleur(coordonneesLisses, iTime).g;
    //couleurResultat.b = calculerCouleur(coordonneesLisses - directionRayon * decalageChromatique, iTime).b;

    couleurResultat = couleurResultat.rrr;
    vec3 flouLumineux = vec3(0.0);
    float ecartFlou = 0.005;
    //flouLumineux += calculerCouleur(coordonneesLisses + vec2(ecartFlou, 0.0), iTime);
    //flouLumineux += calculerCouleur(coordonneesLisses + vec2(-ecartFlou, 0.0), iTime);
    //flouLumineux += calculerCouleur(coordonneesLisses + vec2(0.0, ecartFlou), iTime);
    //flouLumineux += calculerCouleur(coordonneesLisses + vec2(0.0, -ecartFlou), iTime);
    couleurResultat += flouLumineux * 0.15;

    couleurResultat = pow(couleurResultat, vec3(0.85));

    float vignettage = smoothstep(1.3, 0.2, length(coordonneesLisses));
    couleurResultat *= vignettage;

    return dot(couleurResultat, vec3(0.2126, 0.7152, 0.0722));
}

//float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));