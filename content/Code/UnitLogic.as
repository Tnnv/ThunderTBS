class UnitLogic : Behaviour {

    int team;
    private bool isMoving = false;
    private int actionPoints = 100;
    private UnitLogic@ closestEnemy;
    private float distanceToEnemy;
    private int health = 100;
    private float shooting_time;
    private int shooting_ap = 20;
    private int shooting_dmg = 30;
    private float attack_distance = 5.0f;
    private float speed = 3.0f;
    
    Prefab @projectilePrefab = null;
    Prefab @widgetPrefab = null;
    private Actor@ projectileRef = null;
    Actor@ widgetRef = null;
    Actor@ baseWidgetRef = null;
    //Prefab @unitWidget = null;


    // Use this to initialize behaviour
    void start() override {
        @projectileRef = instantiate(projectilePrefab, Vector3(0.0f, 0.2f, 0.0f), Quaternion(Vector3(0.0f, 0.0f, 0.0f)));
        projectileRef.enabled = false;
        //@widgetRef = cast<Actor>(instantiate(widgetPrefab, Vector3(0.0f, 0.0f, 0.0f), Quaternion(Vector3(0.0f, 0.0f, 0.0f))));
        //Transform @t = widgetRef.transform();
        //t.position = Vector3(55.0f, 50.0f, 0.0f);
        //debug("Widget added 1");
    }
    
    
    void updateWidgetPosition() {
        Transform @wt = widgetRef.transform();
        Camera @camera_component = Camera::current();
        Matrix4 vm = camera_component.viewMatrix();
        Matrix4 pm = camera_component.projectionMatrix();
        Transform @t = actor().transform();
        //debug(wt.position.x + "");
        Vector2 vc = camera_component.project(t.position);
        wt.position = Vector3(vc.x * 1400.0f - 700.0f, vc.y * 900.0f - 450.0f, 0.0f);
        //wt.position = Vector3(0.0f, 100.0f, 0.0f);
    }


    // Will be called each frame. Use this to write your game logic
    void update() override {
        
        updateWidgetPosition();
        
        Transform @t = actor().transform();
        
        if(t !is null and isMoving) {
            if(actionPoints > 0) {
                distanceToEnemy = (closestEnemy.actor().transform().position - t.position).length();
                if (distanceToEnemy > attack_distance) {
                    Vector3 directionToEnemy = closestEnemy.actor().transform().position - t.position;
                    directionToEnemy.normalize();
                    Vector3 position = t.position + directionToEnemy * Timer::deltaTime() * speed;
                    t.position = position;
                    t.rotation = Vector3(0.0f, atan2(directionToEnemy.x, directionToEnemy.z) * 57.2958f + 180.0f, 0.0f);
                    setAP(actionPoints - 1);
                } else {
                    isMoving = false;
                    attackEnemy();
                }
            } else {
                isMoving = false;
                TurnBasedController::startNextUnitTurn();
            }
        }
        if(shooting_time > 0) {
            shooting_time = shooting_time - Timer::deltaTime();
            float distanceToEnemy = (closestEnemy.actor().transform().position - actor().transform().position).length();
            Transform @p_t = projectileRef.transform();
            
            if (shooting_time <= 0) {
                projectileRef.enabled = false;
                p_t.position = Vector3(0.0f, 0.2f, 0.0f);
                closestEnemy.hit(shooting_dmg);
                selectAction();
            } else {
                p_t.position = Vector3(0.0f, 0.2f, (1.0f - shooting_time / 0.5f) * -1.0f * (distanceToEnemy - 1.5f) - 1.5f);
            }
        }
    }


    void updateWidget() {
        Label @info_label = cast<Label>(widgetRef.componentInChild("Label"));
        if(health <= 0) {
            info_label.text = "Destroyed";
        } else {
            info_label.text = "AP: " + actionPoints + " HP: " + health;
        }
    }


    void startTurn() {
        setAP(100);
        selectAction();
    }


    void selectAction() {
        if (actionPoints > 0) {
            setClosestEnemyAndDistance();
            if(@closestEnemy != null) {
                if (distanceToEnemy > attack_distance) {
                    //Vector3 directionToEnemy = closestEnemy.actor().transform().position - actor().transform().position;
                    //directionToEnemy.normalize();
                    //actor().transform().rotation = Vector3(0.0f, directionToEnemy.angle(Vector3(1.0f, 0.0f, 0.0f)) - 90.0f, 0.0f);
                    isMoving = true;
                } else {
                    attackEnemy();
                }
            }
        } else {
            TurnBasedController::startNextUnitTurn();
        }
    }


    void attackEnemy() {
        if (actionPoints >= shooting_ap) {
            Transform @t = actor().transform();
            Vector3 directionToEnemy = closestEnemy.actor().transform().position - t.position;
            directionToEnemy.normalize();
            t.rotation = Vector3(0.0f, atan2(directionToEnemy.x, directionToEnemy.z) * 57.2958f + 180.0f, 0.0f);
            setAP(actionPoints - shooting_ap);
            shooting_time = 0.5f;
            projectileRef.enabled = true;
        } else {
            TurnBasedController::startNextUnitTurn();
        }
    }


    void hit(int damage) {
        //debug(string(damage));
        setHP(health - damage);
        debug("Taking hit");
        if(health <= 0) {
            die();
        }
    }


    void die() {
        if(team == 0) {
            int index = TurnBasedController::unitsAllies.findByRef(this);
            TurnBasedController::unitsAllies.removeAt(index);
        } else {
            int index = TurnBasedController::unitsEnemies.findByRef(this);
            TurnBasedController::unitsEnemies.removeAt(index);
        }
        debug("Destroyed");
        TurnBasedController::updateGameInfo();
        //actor().transform().scale = Vector3(0.1f, 0.1f, 0.1f);
        actor().enabled = false;
        widgetRef.enabled = false;
    }


    void setClosestEnemyAndDistance() {
        
        distanceToEnemy = 1000.0f;
        UnitLogic@ closestEnemyUnit;
        array<UnitLogic@> enemyUnits;
        @closestEnemy = null;
        
        if(team == 0) {
            if(TurnBasedController::unitsEnemies.length() > 0) {
                enemyUnits = TurnBasedController::unitsEnemies;
            } else {
                TurnBasedController::startNextUnitTurn();
            }
        } else {
            if(TurnBasedController::unitsAllies.length() > 0) {
                enemyUnits = TurnBasedController::unitsAllies;
            } else {
                TurnBasedController::startNextUnitTurn();
            }
        }
        
        if(enemyUnits.length() > 0) {
            for(uint x = 0; x < enemyUnits.length(); x++) {
                float distance = (enemyUnits[x].actor().transform().position - actor().transform().position).length();
                if (distance < distanceToEnemy) {
                    distanceToEnemy = distance;
                    @closestEnemyUnit = enemyUnits[x];
                }
            }
            @closestEnemy = closestEnemyUnit;
        }
    }

    
    void setAP(int new_ap) {
        actionPoints = new_ap;
        updateWidget();
    }

    
    void setHP(int new_hp) {
        health = new_hp;
        updateWidget();
    }
};